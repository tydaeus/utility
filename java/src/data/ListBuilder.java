package data;

import java.util.List;

/**
 * Convenience class which applies the builder pattern to a list, for purposes
 * of modifying it; in particular, provides a typesafe alternative to varargs
 * list construction.
 *
 * Created by Tydaeus on 8/27/2015.
 */
public class ListBuilder <T, L extends List<T>> {
    private L constructionList;

    /**
     * create a new ListBuilder
     * @param constructionList the list to operate on
     */
    public ListBuilder(L constructionList) {
        this.constructionList = constructionList;
    }

    /**
     * calls add(element) on the contained list
     * @see java.util.List#add(Object)
     * @return this ListBuilder for chaining
     */
    public ListBuilder<T, L> add(T element) {
        constructionList.add(element);
        return this;
    }

    /**
     * calls add(index, element) on the contained list
     * @see java.util.List#add(int, Object)
     * @return this ListBuilder for chaining
     */
    public ListBuilder<T, L>add(int index, T element) {
        constructionList.add(index, element);
        return this;
    }

    /**
     * @return the contained list (for when building is done)
     */
    public L getList() {
        return constructionList;
    }
}
